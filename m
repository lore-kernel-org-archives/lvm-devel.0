From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 19 Mar 2010 16:39:36 -0500
Subject: [PATCH] dmeventd: don't kill the parent if not forking
In-Reply-To: <Pine.LNX.4.64.1003181921450.25153@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.1003181921450.25153@hs20-bc2-1.build.redhat.com>
Message-ID: <470AA26D-236B-4A22-9362-8FD83D289C88@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

funny :)

  ack


On Mar 18, 2010, at 6:23 PM, Mikulas Patocka wrote:

> Don't kill the parent if debugging and not forking.
>
> If dmeventd runs with -d flag, it doesn't fork into backgroud.
> The command kill(getppid(), SIGTERM) attempts to kill the parent  
> dmeventd
> process, however, if there is no parent, it kills whatever process  
> spawned
> dmeventd. In case of debugging with gdb, the parent is gdb, thus
> kill(getppid(), SIGTERM) kills the debugger.
>
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
>
> ---
> daemons/dmeventd/dmeventd.c |    3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)
>
> Index: LVM2/daemons/dmeventd/dmeventd.c
> ===================================================================
> --- LVM2.orig/daemons/dmeventd/dmeventd.c	2010-03-19  
> 00:12:00.000000000 +0100
> +++ LVM2/daemons/dmeventd/dmeventd.c	2010-03-19 00:13:15.000000000  
> +0100
> @@ -1734,7 +1734,8 @@ int main(int argc, char *argv[])
> 		exit(EXIT_FIFO_FAILURE);
>
> 	/* Signal parent, letting them know we are ready to go. */
> -	kill(getppid(), SIGTERM);
> +	if (!_debug)
> +		kill(getppid(), SIGTERM);
> 	syslog(LOG_NOTICE, "dmeventd ready for processing.");
>
> 	while (!_exit_now) {
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


