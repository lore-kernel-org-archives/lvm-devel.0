From: Lakshmi Narasimhan Sundararajan <lns@portworx.com>
Date: Mon, 12 Aug 2019 10:12:02 +0530
Subject: Reg concurrent access through lvmapp api
In-Reply-To: <5d4d1831.1c69fb81.38595.d627@mx.google.com>
References: <5d4d1831.1c69fb81.38595.d627@mx.google.com>
Message-ID: <5d50ee1b.1c69fb81.fdf43.ce3c@mx.google.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gentle reminder? I would sincerely appreciate clarification on the below.

Regards
LN
Sent from Mail for Windows 10

From: Lakshmi Narasimhan Sundararajan
Sent: Friday, August 9, 2019 12:22 PM
To: lvm-devel@redhat.com
Subject: Reg concurrent access through lvmapp api

Hi Team,
Is concurrent access to operations on lvm through lvm2app api possible?
I expected lvm2app api call to be self aware of multiple operations and lock access internal, but I see some crash while doing device creation/deletion and query in parallel.

So my question is, are basic crud (create/read/update and delete) operations on a vg safe to be operated concurrently through the lvm2app api calls? 
If not, what kind of restrictions does the end app needs to know while using lvm2app api calls?

I also understand that the cli uses a /run/lvm/lvm.lock file to control concurrent access. So does it imply that applications have to enforce serialization? If yes, what are the cases for which this needs to be enforced.

Seeking some clarity on the same.

Regards
LN
Sent from Mail for Windows 10


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190812/4c1df0fb/attachment.htm>
