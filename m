From: Milan Broz <mbroz@redhat.com>
Date: Sun, 30 Jan 2011 21:22:47 +0100
Subject: [PATCH 02/24] Replace PV_MIN_SIZE with function pv_min_size()
In-Reply-To: <4D45C6F3.5000000@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>	<10a41c93f0c3f21e0ed40a74184001ca6b51bd19.1296391340.git.zkabelac@redhat.com>	<4D45C3AF.7010702@redhat.com>
	<4D45C6F3.5000000@redhat.com>
Message-ID: <4D45C897.3040705@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/30/2011 09:15 PM, Zdenek Kabelac wrote:

> i.e. if you configure pv_min_size = 10MB - you cannot create  smaller PV - as
> it would be invisible in your system - IMHO it could eventually lead to bigger
> confusion - you create small PV, which will be invisible for lvm tools...
> 
> If you want to create and see smaller PV - lvm.conf needs to be set to smaller
> value.

How it differs from filters line in principle?

If you want to see device, you have to set filer properly.

Of course it will prevent pv creation, because device is filtered out,
but on another level.

Milan


