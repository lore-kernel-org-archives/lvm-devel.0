From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 11:40:24 +0100
Subject: [PATCH 28/30] Skip uninitialized macro for scan-build
In-Reply-To: <1191037c596039e3f71a01b02a4534b92fb39ec3.1287994530.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<1191037c596039e3f71a01b02a4534b92fb39ec3.1287994530.git.zkabelac@redhat.com>
Message-ID: <87zku24ktj.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 10:24:35 +0200,
Zdenek Kabelac wrote:
> 
> scan-build reports assigment of ununitialised values.
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>

Ack.  Surprised that works.


