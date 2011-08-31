From: Petr Rockai <prockai@redhat.com>
Date: Wed, 31 Aug 2011 05:34:37 +0200
Subject: [PATCH] Integrate LVMetaD with the build system
Message-ID: <87sjoi45ki.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this is a "compromise" integration: I have kept all the daemon/common
code in a single libdaemon.a, which is completely private. This is
currently linked into the lvmetad binary, and will be linked into LVM
(the client part, since static linking only picks up only symbols that
are actually used). I have also added --disable-lvmetad to ./configure
(i.e. building and using it by default; there's no LVM-side support yet,
but when there is, even when built, it'll still need to be enabled by an
lvm.conf option).

Yours,
   Petr

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvmetad-build.diff
Type: text/x-diff
Size: 8428 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110831/82cab15b/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
