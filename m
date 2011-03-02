From: Petr Rockai <prockai@redhat.com>
Date: Wed, 02 Mar 2011 13:02:52 +0100
Subject: [PATCH] dmeventd -R updates
Message-ID: <8762s1raqb.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi!

As requested by Milan in BZ 454618:

- dmeventd -R will continue to start up even if no dmeventd is currently
  running; I have added a test for this behaviour
- add -R to dmeventd manpage

Petr

-------------- next part --------------
A non-text attachment was scrubbed...
Name: dmeventd-R.diff
Type: text/x-diff
Size: 2615 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110302/7225d2f3/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
