From: Patrick Caulfield <pcaulfie@redhat.com>
Date: Fri, 05 Jan 2007 11:04:38 +0000
Subject: [PATCH] LVM2 RFC: fix return code when exclusive activation fails
Message-ID: <459E30C6.6090102@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I've attached this patch to the bugzilla

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=208993

but I've yet to have any feed back on it, so I thought I'd post it here too.

Possibly the most controversial part of it (I suspect) will be the shifting up of the return codes, this is needed to
keep INCOMPLETE in its rightful place in the severity stakes

patrick
-------------- next part --------------
A non-text attachment was scrubbed...
Name: incomplete.patch
Type: text/x-patch
Size: 3111 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070105/99542398/attachment.bin>
