From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 21 Nov 2007 21:09:22 -0500
Subject: [PATCH mirror 7/13] Fix lvconvert to use collapsing and mirror counting
In-Reply-To: <4744DF34.7090701@ce.jp.nec.com>
References: <4744DF34.7090701@ce.jp.nec.com>
Message-ID: <4744E4D2.7010905@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch changes 2 things in lvconvert:
  1) Add '--collapse' option as an interface for users to
     remove unnecessary mirror layer and collapse the stack.
  2) Use the new lv_mirror_count() to get correct existing_mirrors .

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-stacked-mirror-lvconvert.patch
Type: text/x-patch
Size: 3384 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071121/913d4b73/attachment.bin>
