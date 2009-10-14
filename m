From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 14 Oct 2009 13:58:13 -0500
Subject: Re: [PATCH 2 of 10] LVM: make log_area a list
In-Reply-To: <20091014171609.GA9054@us.ibm.com>
References: <200910082118.n98LIaik014287@hydrogen.msp.redhat.com>
	<20091013014820.GA27349@us.ibm.com>
	<0FBED8C9-24F0-48D7-81E5-A041AA11F03D@redhat.com>
	<20091014171609.GA9054@us.ibm.com>
Message-ID: <02C2BD80-BFCD-47EB-9685-43EB20ABD053@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Oct 14, 2009, at 12:16 PM, malahal at us.ibm.com wrote:

> My understanding is that the current code executes the inner loop to
> completion every time.

I see what you are saying.  Ok, fixed in my local patch.

  brassow


