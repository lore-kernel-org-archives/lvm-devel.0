From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Jul 2014 16:52:58 +0200
Subject: master - test: Test failing due to too few PVs
In-Reply-To: <20140710235401.E9FA261100@fedorahosted.org>
References: <20140710235401.E9FA261100@fedorahosted.org>
Message-ID: <53BFFA4A.8090100@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 11.7.2014 01:54, Jonathan Brassow napsal(a):
> Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f33d75e2e586a88ddeb20d860765f091098b8ab5
> Commit:        f33d75e2e586a88ddeb20d860765f091098b8ab5
> Parent:        3063b48602220b0aa5e1ad7a91dc4ca60d717e36
> Author:        Jonathan Brassow <jbrassow@redhat.com>
> AuthorDate:    Thu Jul 10 18:52:55 2014 -0500
> Committer:     Jonathan Brassow <jbrassow@redhat.com>
> CommitterDate: Thu Jul 10 18:53:46 2014 -0500
>
> test: Test failing due to too few PVs
>
> Commit 33d69162e4b45e7926d4c0e4a425fedb4246088e reduced the number of
> PVs to a level where the test could not function.  (It is impossible
> to replace 3 PVs of a 4-way RAID1 LV if there are only 5 PVs.)
> ---

Oops those changes leaked from my local repo patches when I'm doing
some tests for failing conditions.

Thanks for noticing and restoring.

Zdenek


