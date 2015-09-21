From: Marian Csontos <mcsontos@redhat.com>
Date: Mon, 21 Sep 2015 16:32:00 +0200
Subject: [PATCH] dmeventd: Fix segfault in _timeout_thread
Message-ID: <560014E0.4040200@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In case thread was found, or thread registration failed after
_register_for_timeout, thread_status was kept in timeout_list after
deallocation.

This should address BZ 1210514 and BZ 1220856.

-- Martian
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 0001-dmeventd-Fix-segfault-in-_timeout_thread.patch
Type: text/x-patch
Size: 3583 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20150921/d0437096/attachment.bin>
