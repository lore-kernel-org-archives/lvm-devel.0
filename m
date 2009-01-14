From: Bryn M. Reeves <bmr@redhat.com>
Date: Wed, 14 Jan 2009 17:26:04 +0000
Subject: lvresize.c: use kilobytes when passing sizes to fsadm
Message-ID: <496E202C.1060009@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi all,

The code in lvresize.c computes a new file system size to pass to 
fsadm when resizing as (extents * extent_size), giving a result in 
kilobytes.

This is then passed on to fsadm without a suffix, meaning that fsadm 
interprets it as a count of the number of file system blocks instead.

This breaks fsadm for all file system block sizes other than 1K.

The attached patch adds a "K" suffix and fixes the problem for me - see:

https://bugzilla.redhat.com/show_bug.cgi?id=480022

For testing details.

Regards,
Bryn.
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: lvm2-lvresize-units.patch
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090114/26d3d877/attachment.ksh>
