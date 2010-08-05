From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 5 Aug 2010 17:16:32 -0500
Subject: [PATCH] Specified PVs being ignored when performing mirror split (bug 619221)
In-Reply-To: <5C30BE7ED8B03E448B2E104602D4848A59228865E7@USINDEVS02.corp.hds.com>
References: <5C30BE7ED8B03E448B2E104602D4848A59228865E3@USINDEVS02.corp.hds.com>,
	<5918B730-E0D8-4B4E-BCC4-D5F9E2143438@redhat.com>
	<5C30BE7ED8B03E448B2E104602D4848A59228865E7@USINDEVS02.corp.hds.com>
Message-ID: <7C138C2B-45EE-4BB2-B4DC-3594A43A87FC@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Aug 5, 2010, at 5:09 PM, Takahiro Yasui wrote:

> On 08/05/10 17:49, Jonathan Brassow wrote:
>> Whether my patch works or not may be irrelevant if your patch is
>> better.  I had considered going through the list backwards to save
>> some processing, but decided to go with the other method...  If this
>> works equally well, let's do it this way instead, yes?
>
> Let me tell you the difference of behavior of yours and mine. When
> the original volume has five devices, A,B,C,D,E and D and E are
> specified as removable devices:
>
> Your patch generates:
>    orginal volume -> A,B,C
>    new volume -> D,E
>
> My suggestion generates:
>    orginal volume -> A,B,C
>    new volume -> E,D
>
> If we have to care the order of new devices, I think your patch is  
> better.

I don't think we do because they get renamed along with the new  
volume.  Will repost new patch shortly.

  brassow


