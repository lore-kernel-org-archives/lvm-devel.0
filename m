From: Petr Rockai <me@mornfall.net>
Date: Thu, 15 Jan 2009 11:34:38 +0100
Subject: [PATCH] Amended vg_read patches.
Message-ID: <1232015684-23781-1-git-send-email-me@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Hi,

I have tried to address most issues that have been voiced here. Since changes
in the first patches required rebasing several other patches, I am sending all
affected patches at once. (Ie. I am omitting patches that did not change.)

I did not change the uint32_t for failure to a typedef yet, I would do that in
a separate patch on top, which I will send as soon as these are re-reviewed.

Yours,
   Petr.


