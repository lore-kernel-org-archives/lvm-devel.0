From: Robert Milasan <rmilasan@suse.com>
Date: Fri, 19 Oct 2012 14:33:01 +0200
Subject: clvmd always sets debug level to DEBUG_SYSLOG
Message-ID: <20121019143301.4cc7e9ac@coolcat.suse.cz>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,
just realized now that in clvmd.c debugging level is set wrong due to
using the wrong variable in clvmd_set_debug.

If a user run clvmd -d0, usually this means no debugging or DEBUG_OFF,
but 0 argument is saved in debug_arg and debugging level is set using
debug_opt in clvmd_set_debug:

# cat clvmd.c |grep clvmd_set_debug
        clvmd_set_debug(debug_opt);

and it suppose to be: clvmd_set_debug(debug_arg)

Here is the patch:

Index: LVM2.2.02.84/daemons/clvmd/clvmd.c
===================================================================
--- LVM2.2.02.84.orig/daemons/clvmd/clvmd.c
+++ LVM2.2.02.84/daemons/clvmd/clvmd.c
@@ -428,7 +428,7 @@ int main(int argc, char *argv[])
        if (debug_opt && !check_local_clvmd())
                return debug_clvmd(debug_arg, clusterwide_opt)==1?0:1;
 
-       clvmd_set_debug(debug_opt);
+       clvmd_set_debug(debug_arg);
 
        /* Fork into the background (unless requested not to) */
        if (!foreground_mode)


Cheers!

-- 
Robert Milasan

L3 Support Engineer
SUSE Linux (http://www.suse.com)
email: rmilasan at suse.com
GPG fingerprint: B6FE F4A8 0FA3 3040 3402  6FE7 2F64 167C 1909 6D1A


