From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 10:58:41 +0100
Subject: [PATCH 03/30] Check (type) is not NULL before access
In-Reply-To: <381373042f177c1ef15516a944adff25149c7a6f.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<381373042f177c1ef15516a944adff25149c7a6f.1287994529.git.zkabelac@redhat.com>
Message-ID: <87tyka61bi.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 10:24:10 +0200,
Zdenek Kabelac wrote:
> 
> clang Logic error	Dereference of null pointer

Should a generic warning be given if |type| is NULL?


