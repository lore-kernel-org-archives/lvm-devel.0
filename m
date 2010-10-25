From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 10:59:10 +0100
Subject: [PATCH 05/30] Print vg_name and do not to access vg->name
In-Reply-To: <4ed74f138478e118c6a7e418aa638d72c913d4d3.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<4ed74f138478e118c6a7e418aa638d72c913d4d3.1287994529.git.zkabelac@redhat.com>
Message-ID: <87sjzu61ap.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 10:24:12 +0200,
Zdenek Kabelac wrote:
> 
> clang Logic error Dereference of null pointer
> Replacing pointer access with vg_name.
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>

Ack


