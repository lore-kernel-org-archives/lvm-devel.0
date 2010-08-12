From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 12 Aug 2010 10:56:17 +0200
Subject: [PATCH] clvmd init exit 4 when executed by non-root user
Message-ID: <4C63B731.90407@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Once again and hopefully for the last time..

clvmd daemon itself does the right thing when invoked as non-root, by
returning 4.

The patch removes the use daemon function from
/etc/rc.d/init.d/functions that?s unnecessary and has the bad habit to
mask the return codes from the real daemon.

Add a simple and generic check to see if clvmd is executed by root or not.

Our stop/reload/restart paths in the init script are complex and not all
the tools involved in the process are guaranteed to return 4 if executed
by non-root against a process that?s running as root (for example kill
-TERM will return -1 and parsing the output to catch the error is
suboptimal at best).

Fabio
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: clvmd_init_exit4.patch
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100812/76734612/attachment.ksh>
