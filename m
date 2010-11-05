From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 05 Nov 2010 16:05:51 +0100
Subject: [PATCH 3/3] ocf support
In-Reply-To: <23bf9e224c03d73cd1b4c82bf2e5e29d17d10efb.1288706876.git.zkabelac@redhat.com>
References: <cover.1288706876.git.zkabelac@redhat.com>
	<23bf9e224c03d73cd1b4c82bf2e5e29d17d10efb.1288706876.git.zkabelac@redhat.com>
Message-ID: <4CD41D4F.5050103@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 2.11.2010 15:10, Zdenek Kabelac napsal(a):
> Updated patch from Florian Haas from Linux-HA project.
> 
> CF patch:
>   user needs to configure --enable-ocf so it gets installed with
>   make install target by default. Otherwise user can use:
>   make install_ocf to get only ocf files installed.
>   With disabled (default) ocf support - no files are installed.
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
> ---


Updated version with ocf_scriptdir defined in  make.tmpl.in

Zdenek
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 0003-ocf-support.patch
Type: text/x-patch
Size: 11907 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101105/be4aec88/attachment.bin>
