From: Tony Asleson <tasleson@redhat.com>
Date: Thu, 25 Apr 2013 18:14:35 -0500
Subject: [PATCH 1/2] lvm2app: Add thin and thin pool lv creation
In-Reply-To: <512FD2B8.5030009@redhat.com>
References: <1360689876-13552-1-git-send-email-mohan@in.ibm.com>
	<1360689876-13552-2-git-send-email-mohan@in.ibm.com>
	<512BBF6B.3060004@redhat.com> <87wqtsznrx.fsf@in.ibm.com>
	<512F7928.80209@redhat.com> <512FBF12.30803@redhat.com>
	<512FD2B8.5030009@redhat.com>
Message-ID: <5179B8DB.2010805@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 02/28/2013 03:57 PM, Zdenek Kabelac wrote:
> Dne 28.2.2013 21:33, Tony Asleson napsal(a):
>> On 02/28/2013 09:35 AM, Zdenek Kabelac wrote:
>>> As you could see yourself - it's getting to be a lvm2api user's problem
>>> to figure out, how to actually create a specific LV - API user would
>>> need to scan number of 'lvcreate' function and try to figure out which
>>> function to call, instead of having single call with  'lvcreate_params'
>>> - so IMHO I'd prefer to avoid creating this 'array' of 'simple'
>>> interfaces even though all those functions could be possible later
>>> turned into wrappers calling one universal function - but why not start
>>> directly with the proper way.
>>
>> Obviously there are pros and cons to either approach.  In my opinion
>> having a single function call that takes 20 parameters is no easier to
>> use than a 20 separate function calls.  The complexity is present in
>> both.
>>
>> In my opinion it would be useful to have a simple function that
>> satisfies 90% of what most users use and then have one or two addition
>> functions that satisfy the other corner cases.
>>
>> To date I believe the following options have been proposed (please
>> correct):
>>
>> 1. Separate functions with varying amounts of increased functionality
>> 2. One function that does everything
>>    a. Expose large structure for parameters
>>    b. Expose string with one or parameters embedded in it
>>    c. Set/get functions on an opaque data structure which en-composes all
>> the options (eg. getsockopt/setsockopt)
>>
>> I believe that whatever we choose needs to be able to accommodate future
>> change as new things will be added over time.
>>
>> 2a. Exposing a large structure has the problem of how you extend it over
>> time.  Do you create a new structure and create a new function that
>> takes that new structure or do you pass a void type with a size and
>> select the structure based on size etc.  Once you expose it, it can
>> never change.
>>
>> 2b. Using a string for parameters introduces a different set of issues.
>>   The client needs to be able to correctly create the string.  The
>> library needs to parse the string.  You lose type safety and you don't
>> know until run-time that the parameters are correct/incorrect.
>>
>> 2c. This option requires more code, but allows you to change the
>> implementation of the API and allows you to extend the API easily.
>>
>> Obviously it is easy to see that I favor option 2c.  This is also the
>> suggested way by others as well (https://github.com/shepjeng/libabc).
> 
> API should never expose structure - only handlers, so obviously 2c is
> the only way.
> 
> My idea here would be - we may add multiple different functions
> how to create  'lvcreate_params' 'object'.

I initially was thinking the same way, but now I'm asking myself is it
any easier to have a bunch of initializer functions to create an object
that has to be passed to one function that does the work instead of
number of functions?  With this new object we have yet one more piece of
memory on the heap that needs to be cleaned up to prevent leaks after
the call is completed.  Not a horrible requirement, but kind of a pain
for the simple generic use cases.

Realistically, how many different default constructor/initializer are we
looking at?

> So there could be a simple function call to prepare such object
> for thin volume creation - or for snapshot of an LV.
> And then having separate 'tiny' functions  get/set for individual options
> we support.

In OOA/OOP having many get and set functions for a class can be
indicative of a poor design.  Ideally objects should have data and
behavior.  In this case we have an object for the sole purpose as an
encapsulated parameter passer.  Ideally the get/set functions would only
be available for those options that are common to all lv parameters.
Otherwise a user could be setting or getting a value that has absolutely
no meaning in their context.  We could achieve this by having the
initializers functions take parameters that only pertain to them, but we
are then creating complexity for non advanced use cases who just want to
use the defaults.

We could also create a different object parameter type for each use
case, but then we end up having more functions to pass the parameter too
if we want to maintain type safety.  However, we would ensure that
get/set functions would not get called spuriously.

> But there should be one entrance to 'lvm_lvcreate' function with such
> object.
> 
> API should also be replaceable for the current API used by lvm commands,
> so those should be converted to use lvm library over the time as well.
> 
> So that's why I'm proposing to go with  lvcreate_params way - since this
> way we may get relatively nice mapping.
> 
> Though the command are doing massive 'validation' of options - and the
> question is - is this validation supposed to be happing also with lvm2api?
> If so - that's another thing which will require some thinking.

The validation should be done in one spot for both.  In my opinion the
code should parse the arguments and then call the appropriate function
which in turn validates the values.  Otherwise we have duplicate code
and more opportunities to fix the same bug more than once.

At the moment I've kind of exhausted everything I can think of.  Does
anyone else have any ideas that would lend itself to an API that can
accommodate a plethora of configurable options, allow a sane default for
common uses cases and not create any potential opportunities for
incorrect use?

Regards,
Tony


