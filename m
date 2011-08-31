From: Petr Rockai <prockai@redhat.com>
Date: Wed, 31 Aug 2011 16:30:10 +0200
Subject: [PATCH] non-const dm_config_find_node
Message-ID: <87k49t4psd.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this patch replaces const usage of dm_config_find_node with more
appropriate value-lookup functionality. A number of bugs (copied and
pasted all over the code) should disappear:

- most string lookup based on dm_config_find_node would segfault when
  encountering a non-zero integer (the intention there was to print an
  error message instead)
- check for required sections in metadata would have been satisfied by
  values as well (i.e. not sections)
- encountering a section in place of expected flag value would have
  segfaulted (due to assumed but unchecked cn->v != NULL)

Yours,
   Petr

-------------- next part --------------
A non-text attachment was scrubbed...
Name: dm_config_find_node.diff
Type: text/x-diff
Size: 19939 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110831/54fa69e5/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
