From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 21 Nov 2007 21:09:54 -0500
Subject: [PATCH mirror 12/13] Allow renaming of mirrored LV with temporary layer
In-Reply-To: <4744DF34.7090701@ce.jp.nec.com>
References: <4744DF34.7090701@ce.jp.nec.com>
Message-ID: <4744E4F2.5040602@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

_for_each_sub_lv() is a function used to execute same function
for each LVs used in a given LV's segments.
It's used for lv_rename() to implement mirrored LV renaming.

When we have temporary layers in mirrored LV, mirrored LV is
no longer flat. So _for_each_sub_lv() should work recursively.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-stacked-mirror-rename.patch
Type: text/x-patch
Size: 827 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071121/2ca25828/attachment.bin>
