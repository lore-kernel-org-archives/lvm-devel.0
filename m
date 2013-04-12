From: Tony Asleson <tasleson@redhat.com>
Date: Fri, 12 Apr 2013 10:21:46 -0500
Subject: [PATCH V4] lvm2app: Add thin and thin pool lv creation
In-Reply-To: <516800C9.8000505@redhat.com>
References: <1363713892-14704-1-git-send-email-mohan@in.ibm.com>
	<515DF3F3.70004@redhat.com> <87zjx47x7a.fsf@in.ibm.com>
	<516800C9.8000505@redhat.com>
Message-ID: <5168268A.6040701@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/12/2013 07:40 AM, Zdenek Kabelac wrote:
 > We really need here separate type of object to set all properties for
thin.
> (Since their amount will grow over the time) so you can't solve with any
> bit field - this is not extensible.
> 
> We need to create 'object' with properties, that can be controled in C++
> like way - so we may extend it in future easily, without breaking API,
> and leaving
> 'old' unusable calls in the library.

I will take a swag at something early next week and post for people to
review.  We need to get something in soon so that people can utilize the
new thinp stuff.

-Tony


