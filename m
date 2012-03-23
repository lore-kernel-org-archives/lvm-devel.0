From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Fri, 23 Mar 2012 12:04:53 +0100
Subject: [PATCH] integrate veritysetup to lvm
In-Reply-To: <Pine.LNX.4.64.1203212257230.29962@file.rdu.redhat.com>
References: <Pine.LNX.4.64.1203212139410.18255@file.rdu.redhat.com>
	<Pine.LNX.4.64.1203212257230.29962@file.rdu.redhat.com>
Message-ID: <4F6C58D5.7050607@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 22.3.2012 04:33, Mikulas Patocka napsal(a):
> Hi
> 
> This patch integrates veritysetup to lvm build. Use --enable-veritysetup 
> to enable it.
> 

> ---
>  Makefile.in               |    8 
>  configure.in              |   64 +++
>  veritysetup/Makefile.in   |   31 +
>  veritysetup/veritysetup.c |  948 ++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 1050 insertions(+), 1 deletion(-)
> 


Why not using /tools  like with do with the rest ?

Also I think some basic man page with examples of usage needs to be bundled
with introduction of new supported tool.

Zdenek


