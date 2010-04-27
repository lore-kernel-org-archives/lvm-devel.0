From: Petr Rockai <prockai@redhat.com>
Date: Tue, 27 Apr 2010 20:03:47 +0200
Subject: [PATCH] handle transient errors in lvconvert --repair
In-Reply-To: <87y6g99bbg.fsf@twilight.int.mornfall.net.> (Petr Rockai's
	message of "Tue, 27 Apr 2010 17:14:59 +0200")
References: <87y6g99bbg.fsf@twilight.int.mornfall.net.>
Message-ID: <87pr1kai2k.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

A couple issues slipped into last patch, this is a fixed version (no
regex debris, fixed testcase).

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-repair-transient.diff
Type: text/x-diff
Size: 22931 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100427/55914445/attachment.bin>
