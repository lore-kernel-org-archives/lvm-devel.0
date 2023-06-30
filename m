From: Marian Csontos <mcsontos@redhat.com>
Date: Fri, 30 Jun 2023 12:26:31 +0200
Subject: Source code repository has moved to gitlab.com
Message-ID: <CAJNi=XonpP-=FOG2xL0kjwnm0+-qOVStOgPi64_D=H6bcznqtQ@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvm2 sourcecode repository has moved to https://gitlab.com/lvmteam/lvm2

In your git repository run:

    git remote rename origin sourceware
    git remote add origin git at gitlab.com:lvmteam/lvm2.git

This will require setting tracking branches:

    git branch --set-upstream-to origin/main main

Or in .git/config replace origin's URL with new one:

    git at gitlab.com:lvmteam/lvm2.git

Not all branches were mirrored to new repository

-- Marian
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230630/d05b95db/attachment.htm>
