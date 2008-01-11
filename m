From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 11 Jan 2008 18:47:38 -0500
Subject: [PATCH 7/11] lvconvert adds/removes mirror log to/from the original LV
In-Reply-To: <4787FA27.8050300@ce.jp.nec.com>
References: <4787FA27.8050300@ce.jp.nec.com>
Message-ID: <4788001A.60304@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If mirror log addition/removal was requested during conversion,
lvconvert should manipulate on the original LV, not the top-level LV.

Use find_tmp_mirror() to find out the original LV.

-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-add-remove-log-original-lv.patch
Type: text/x-patch
Size: 2429 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080111/6f8ff7b6/attachment.bin>
