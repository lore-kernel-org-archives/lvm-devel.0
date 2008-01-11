From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 11 Jan 2008 18:48:41 -0500
Subject: [PATCH 9/11] _init_mirror_log() to cope with activation status
In-Reply-To: <4787FA27.8050300@ce.jp.nec.com>
References: <4787FA27.8050300@ce.jp.nec.com>
Message-ID: <47880059.4020104@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

_init_mirror_log() is a function to initialize mirror log contents
with necessary activation and cleanups.
The function was originaly made for log_lv, which is just created
and not active.

For the log (re-)initialization, it's nice if the function takes
care of the current activation status and the intent of the caller
for the failure case.

-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: init_mirror_log-cope-with-existing-active-log.patch
Type: text/x-patch
Size: 3184 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080111/d7de6533/attachment.bin>
