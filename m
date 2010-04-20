From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 20 Apr 2010 16:07:00 +0200
Subject: Using glibc regex
Message-ID: <4BCDB504.2080104@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch replaces internal  dm_regex and uses  glibc regex routines so we
achieve better performance for things like hundreds patterns.

Needs some testing...

Zdenek

-------------- next part --------------
A non-text attachment was scrubbed...
Name: 0001-Switch-to-glibc-regex-to-speedup-pattern-matching.patch
Type: text/x-patch
Size: 9246 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100420/3bdf39bf/attachment.bin>
