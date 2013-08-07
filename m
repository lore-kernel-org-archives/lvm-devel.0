From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Wed, 07 Aug 2013 11:21:44 +0200
Subject: master - RAID: Make "raid1" the default mirror segment type
In-Reply-To: <20130806191451.F216960F6C@fedorahosted.org>
References: <20130806191451.F216960F6C@fedorahosted.org>
Message-ID: <520211A8.3010901@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 6.8.2013 21:14, Jonathan Brassow napsal(a):
> Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7e1083c985fd130b240c2471643350cc5c0f05cf
> Commit:        7e1083c985fd130b240c2471643350cc5c0f05cf
> Parent:        f74e8fe04471a44fe1ab0645e48c9cb06ef6fb4f
> Author:        Jonathan Brassow <jbrassow@redhat.com>
> AuthorDate:    Tue Aug 6 14:13:55 2013 -0500
> Committer:     Jonathan Brassow <jbrassow@redhat.com>
> CommitterDate: Tue Aug 6 14:13:55 2013 -0500
>
> RAID: Make "raid1" the default mirror segment type
>
> ---
>   WHATS_NEW             |    1 +
>   conf/example.conf.in  |    2 +-
>   lib/config/defaults.h |    2 +-
>   man/lvconvert.8.in    |    7 ++++++-
>   man/lvcreate.8.in     |   17 ++++++++++++-----
>   5 files changed, 21 insertions(+), 8 deletions(-)
>
> diff --git a/WHATS_NEW b/WHATS_NEW
> index fd7e39f..3590e64 100644
> --- a/WHATS_NEW
> +++ b/WHATS_NEW
> @@ -1,5 +1,6 @@
>   Version 2.02.100 -
>   ================================
> +  Make "raid1" the default mirror segment type.
>     Fix clogd descriptor leak when daemonizing.
>     Fix clvmd descriptor leak on restart.
>     Add pipe_open/close() to replace less secure popen() glibc call.
> diff --git a/conf/example.conf.in b/conf/example.conf.in
> index 0e313c8..c3ba2b9 100644
> --- a/conf/example.conf.in
> +++ b/conf/example.conf.in
> @@ -512,7 +512,7 @@ global {
>       #
>       # Specify the '--type <mirror|raid1>' option to override this default
>       # setting.
> -    mirror_segtype_default = "mirror"
> +    mirror_segtype_default = "raid1"
>


We need fallback here - since if the user doesn't have dm-raid -  then he 
needs to manually configure defaults.

As a result automated tests on systems without dm raid fails.

Also we need to update all tests which were supposed to test mirrors,
to really test mirrors - otherwise we are checking raid code twice
(and even without checking  dm-raid version presence)

Zdenek





