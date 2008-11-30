From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun, 30 Nov 2008 09:57:47 -0500
Subject: [PATCH 1/4] Move guts of pvcreate into library area - prep for vgcreate.
In-Reply-To: <20081130042620.GF13235@agk.fab.redhat.com>
References: <1227992553-4381-1-git-send-email-dwysocha@redhat.com>
	<20081130042620.GF13235@agk.fab.redhat.com>
Message-ID: <1228057068.3315.33.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Sun, 2008-11-30 at 04:26 +0000, Alasdair G Kergon wrote:
> I'm a bit bothered that too much code may be getting dumped into the library here
> wholesale rather than getting broken up into separate calls.
> 
> - I don't think the library should be prompting, that should remain at tools level
> and the interface should allow for that.
> -- maybe yes_no_prompt needs some global mode (anaconda would set) to control
> whether it does anything or simply defaults to the value given in an additional
> parameter 
> 

Why global mode - why not just set 'force' and '-y' for the API call?  I
think this was similar to Thomas's argument - he always envisioned '-ff'
and '-y' on things like pvcreate.

To be specific, in pvcreate we prompt if:
1) the device is already a PV
2) we find an MD superblock
(and of course the user has not given the '-ff' and '-y')

So if we don't want the yes_no_prompt() in the library, either the
library calls do not do these checks at all, or we duplicate the code in
the library.  Otherwise, we leave the yes_no_prompt() code in the
library and just set the options for the API call.

Note that we currently have yes_no_prompt() in the library for lvremove
and vgremove code paths.  The pvcreate/vgremove/lvremove paths might
also be a good area to talk about the error codes/handling and what the
API should look like.


