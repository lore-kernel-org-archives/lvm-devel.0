From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 10:46:40 +0100
Subject: [PATCH 01/30] Fix clang warning for ntohl(*((uint32_t *)buf))
In-Reply-To: <37b83dcc9cb1168d88a1e665654c8bbf1c299879.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<37b83dcc9cb1168d88a1e665654c8bbf1c299879.1287994529.git.zkabelac@redhat.com>
Message-ID: <87y69m61vj.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 10:24:08 +0200,
Zdenek Kabelac wrote:
> 
> We cast (char*) to (uint32_t*) that changes alignment requierements.
> For our case the code has been correct as alloca() returns properly
> aligned buffer, however this patch make it cleaner and more readable
> and avoids warning generation.
> 
> FIXME: code duplication
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>

Ack


