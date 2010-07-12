From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Mon, 12 Jul 2010 11:37:50 +0200
Subject: [PATCH] pid files cleanup take 2
Message-ID: <4C3AE26E.40900@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi all,

this new patch moves create_lockfile to dm_create_lockfile (dm-file.c),
addresses the return code issue and switch also dmeventd to use the
generic implementation.

autoreconf executed on F-12.

NOTE: dmeventd has, in its current implementation, a slightly more
detailed error handling of the pid file. See the 2 return codes that are
not necessary any longer by using dm_create_lock.
If current behavior of dmeventd has to be retained, then we can simply
modify dm_create_lockfile to return different values depending on the
error and dmeventd can simply re-map them for its needs.

Cheers
Fabio
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: pid_files2.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100712/3ad8768a/attachment.ksh>
