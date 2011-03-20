From: Petr Rockai <prockai@redhat.com>
Date: Sun, 20 Mar 2011 11:10:54 +0100
Subject: [PATCH] dmeventd protocol versioning mechanism
Message-ID: <877hbunlu9.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the attached patch adds rudimentary versioning to the dmevend protocol,
allowing us to detect the (protocol) version of the running dmeventd on
the client side.

Right now this is only used in dmeventd -R.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: dmeventd-protocol-version.diff
Type: text/x-diff
Size: 4492 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110320/acd84051/attachment.bin>
-------------- next part --------------

Yours,
   Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
