#import <spawn.h>
#import <notify.h>

extern char **environ;

// Funzione generica per eseguire un comando
static void runCommand(const char *path, const char *args[]) {
    pid_t pid;
    posix_spawn(&pid, path, NULL, NULL, (char * const *)args, environ);
}

// --- Azioni rootless ---
static void doRespring() {
    const char *args[] = {"killall", "-9", "SpringBoard", NULL};
    runCommand("/var/jb/usr/bin/killall", args); // rootless path
}

static void doUserspaceReboot() {
    const char *args[] = {"launchctl", "reboot", "userspace", NULL};
    runCommand("/var/jb/usr/bin/launchctl", args); // rootless path
}

static void doRestart() {
    const char *args[] = {"launchctl", "reboot", "system", NULL};
    runCommand("/var/jb/usr/bin/launchctl", args); // rootless path
}

static void doShutdown() {
    const char *args[] = {"launchctl", "halt", NULL};
    runCommand("/var/jb/usr/bin/launchctl", args); // rootless path
}

// --- Registrazione notifiche ---
%ctor {
    int token;

    notify_register_dispatch("net.checkm8ra1n.quickrefresh.respring",
                             &token,
                             dispatch_get_main_queue(),
                             ^(int t) { doRespring(); });

    notify_register_dispatch("net.checkm8ra1n.quickrefresh.userspaceReboot",
                             &token,
                             dispatch_get_main_queue(),
                             ^(int t) { doUserspaceReboot(); });

    notify_register_dispatch("net.checkm8ra1n.quickrefresh.restart",
                             &token,
                             dispatch_get_main_queue(),
                             ^(int t) { doRestart(); });

    notify_register_dispatch("net.checkm8ra1n.quickrefresh.shutdown",
                             &token,
                             dispatch_get_main_queue(),
                             ^(int t) { doShutdown(); });
}
