From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Fri, 3 Mar 2023 17:49:15 +0530
Subject: lvmetad status
Message-ID: <CAFe+wq235CR3DavwD+z200MAe4-CnWQveF2CX2S5vm0qSmTfLA@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Team!
A very good day to you all.
Can anyone please confirm the current status of lvmetad?
Is this deprecated? On the lvm2 dev branch I see as early as 2018 that it
has been removed, but I do not see any other information anywhere on its
status.

Is there some place where the reason is called out?
I still see distros default flag to use_lvmetad = true and man pages
calling out usage of lvmetad.

Many thanks
LN

// This commit below called out "Remove lvmetad" for 2.03.00 branch
commit f8462cff9224594385c3b9f89785c28995151824 (tag: v2_03_00)
Author: Marian Csontos <mcsontos@redhat.com>
Date:   Tue Aug 21 17:18:20 2018 +0200
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230303/837d7a3e/attachment.htm>
