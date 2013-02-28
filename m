From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 28 Feb 2013 22:57:12 +0100
Subject: [PATCH 1/2] lvm2app: Add thin and thin pool lv creation
In-Reply-To: <512FBF12.30803@redhat.com>
References: <1360689876-13552-1-git-send-email-mohan@in.ibm.com>
	<1360689876-13552-2-git-send-email-mohan@in.ibm.com>
	<512BBF6B.3060004@redhat.com> <87wqtsznrx.fsf@in.ibm.com>
	<512F7928.80209@redhat.com> <512FBF12.30803@redhat.com>
Message-ID: <512FD2B8.5030009@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 28.2.2013 21:33, Tony Asleson napsal(a):
> On 02/28/2013 09:35 AM, Zdenek Kabelac wrote:
>> As you could see yourself - it's getting to be a lvm2api user's problem
>> to figure out, how to actually create a specific LV - API user would
>> need to scan number of 'lvcreate' function and try to figure out which
>> function to call, instead of having single call with  'lvcreate_params'
>> - so IMHO I'd prefer to avoid creating this 'array' of 'simple'
>> interfaces even though all those functions could be possible later
>> turned into wrappers calling one universal function - but why not start
>> directly with the proper way.
>
> Obviously there are pros and cons to either approach.  In my opinion
> having a single function call that takes 20 parameters is no easier to
> use than a 20 separate function calls.  The complexity is present in both.
>
> In my opinion it would be useful to have a simple function that
> satisfies 90% of what most users use and then have one or two addition
> functions that satisfy the other corner cases.
>
> To date I believe the following options have been proposed (please correct):
>
> 1. Separate functions with varying amounts of increased functionality
> 2. One function that does everything
>    a. Expose large structure for parameters
>    b. Expose string with one or parameters embedded in it
>    c. Set/get functions on an opaque data structure which en-composes all
> the options (eg. getsockopt/setsockopt)
>
> I believe that whatever we choose needs to be able to accommodate future
> change as new things will be added over time.
>
> 2a. Exposing a large structure has the problem of how you extend it over
> time.  Do you create a new structure and create a new function that
> takes that new structure or do you pass a void type with a size and
> select the structure based on size etc.  Once you expose it, it can
> never change.
>
> 2b. Using a string for parameters introduces a different set of issues.
>   The client needs to be able to correctly create the string.  The
> library needs to parse the string.  You lose type safety and you don't
> know until run-time that the parameters are correct/incorrect.
>
> 2c. This option requires more code, but allows you to change the
> implementation of the API and allows you to extend the API easily.
>
> Obviously it is easy to see that I favor option 2c.  This is also the
> suggested way by others as well (https://github.com/shepjeng/libabc).

API should never expose structure - only handlers, so obviously 2c is the only 
way.

My idea here would be - we may add multiple different functions
how to create  'lvcreate_params' 'object'.

So there could be a simple function call to prepare such object
for thin volume creation - or for snapshot of an LV.
And then having separate 'tiny' functions  get/set for individual options
we support.

But there should be one entrance to 'lvm_lvcreate' function with such object.

API should also be replaceable for the current API used by lvm commands,
so those should be converted to use lvm library over the time as well.

So that's why I'm proposing to go with  lvcreate_params way - since this
way we may get relatively nice mapping.

Though the command are doing massive 'validation' of options - and the 
question is - is this validation supposed to be happing also with lvm2api?
If so - that's another thing which will require some thinking.


Zdenek


