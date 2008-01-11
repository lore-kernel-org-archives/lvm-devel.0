From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 11 Jan 2008 18:43:56 -0500
Subject: [PATCH 1/11] lvconvert takes '--wait' instead of '--background'
In-Reply-To: <4787FA27.8050300@ce.jp.nec.com>
References: <4787FA27.8050300@ce.jp.nec.com>
Message-ID: <4787FF3C.8010503@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Remove '--background' option and add '--wait' option to lvconvert.

Recent change in lvconvert let it starts polling the conversion by default
for adding mirror(s).
'--background' is an option to immediately exit from the command and
do the polling in background.

The option was inherited from pvmove.
However, since lvconvert used to exit immediately and it still does
for different types of conversion (e.g. linear to mirror conversion),
it's more consistent and intuitive to add '--wait' option for foreground
polling and do it in background by default.

-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-wait-option.patch
Type: text/x-patch
Size: 2932 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080111/38ae8e53/attachment.bin>
