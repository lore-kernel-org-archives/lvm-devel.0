From: Milan Broz <mbroz@redhat.com>
Date: Sun, 30 Jan 2011 21:50:53 +0100
Subject: [PATCH 21/24] Testing: remove -q from grep
In-Reply-To: <56935a36945105a151999d7fed409100ec18c264.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
	<56935a36945105a151999d7fed409100ec18c264.1296391340.git.zkabelac@redhat.com>
Message-ID: <4D45CF2D.2080001@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/30/2011 01:57 PM, Zdenek Kabelac wrote:
> to avoid problems with pipe breaking

yes, calling pipe fitter is quite expensive;-)

ACK.

Milan


