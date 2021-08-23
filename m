From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Mon, 23 Aug 2021 18:55:17 +0530
Subject: Concurrent calls lvm create vs lvm remove
Message-ID: <CAFe+wq3Ag7Br9TtukOn2jSvqmXJMNM=Cq_7DU8WH2rDJ6kYV+Q@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Team!
A very good day to you.
I want to understand how lvm concurrent calls between create and remove for
lvm volumes are handled.

Very rarely, I see that when create and remove lvm volume (over a thin
pool) run in parallel, lvm create fails with no vg. Looking at lvm metadata
debug logs, they seem slightly different with
pv gone, removing empty VG, moving PV to #orphan, and a vg_update which
eventually brings back everything.

How is this race between create and remove handled or more generally if it
applies, how are concurrent calls over lvm protected for consistency?
Are applications supposed to handle this? I would assume no.

My environment is convoluted and may not apply directly, but your help in
pointing to current design and usage rules will help me immensely.

Best regards
LN
* my environment involves containers.
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20210823/e22c74bb/attachment.htm>
