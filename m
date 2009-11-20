From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 20 Nov 2009 18:04:17 +0100
Subject: Patch for opening remote VG for replicator target
Message-ID: <4B06CC11.7090100@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Here is a small patch preview to resolve the problem of opening remote VG for
replicator target. It has still one 'minor' problem - thus I'll send full
patch set once I resolve that as well.

For now -

If remote VG is not active - than activation of local + remote VG successeds.

If remote VG is active - code currently fails and I'm trying to resolve
related problems.

No extra flags seems to be required at this moment. If there is need for
remote VG during _process_one_vg() call than there is loop which tries to
resolve those dependencies. Hopefully this solution does not influence any
other tool or command right now.

Zdenek
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: pat
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20091120/9b6f7033/attachment.ksh>
