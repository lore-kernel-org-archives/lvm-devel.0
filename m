From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 11:44:30 +0100
Subject: [PATCH 29/30] Add some __attribute__ instrumentation
In-Reply-To: <f5e7e192d1da549614124cc96a5669a80feb1680.1287994530.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<f5e7e192d1da549614124cc96a5669a80feb1680.1287994530.git.zkabelac@redhat.com>
Message-ID: <87vd4q4kmp.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 10:24:36 +0200,
Zdenek Kabelac wrote:
> 
> Add some malloc intrumentation and warning attributes.
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>

Ack.  But I question how far you intend to go with this.  Surely it's more unusual to return a value that can be ignored?


