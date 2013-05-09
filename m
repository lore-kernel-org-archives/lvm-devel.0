From: Tony Asleson <tasleson@redhat.com>
Date: Thu, 09 May 2013 08:55:23 -0500
Subject: [PATCH 05/19] lvm2app: Move core lv re-size code (v2)
In-Reply-To: <518B4C96.5020601@redhat.com>
References: <1368053141-13836-1-git-send-email-tasleson@redhat.com>
	<1368053141-13836-6-git-send-email-tasleson@redhat.com>
	<518B4C96.5020601@redhat.com>
Message-ID: <518BAACB.9070407@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 05/09/2013 02:13 AM, Zdenek Kabelac wrote:
> Dne 9.5.2013 00:45, Tony Asleson napsal(a):
>> Moved to allow use from command line and for library use.
>>
>> Signed-off-by: Tony Asleson <tasleson@redhat.com>
>> ---
>>   lib/metadata/lv_manip.c          | 734
>> +++++++++++++++++++++++++++++++++++++
>>   lib/metadata/metadata-exported.h |  46 +++
>>   tools/lvresize.c                 | 773
>> +--------------------------------------
>>   3 files changed, 781 insertions(+), 772 deletions(-)
>>
>> diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
>> index 42e0fab..587cbd2 100644
>> --- a/lib/metadata/lv_manip.c
>> +++ b/lib/metadata/lv_manip.c
>> @@ -27,6 +27,8 @@
>>   #include "activate.h"
>>   #include "str_list.h"
>>   #include "defaults.h"
>> +#include "lvm-exec.h"
>> +#include "errors.h"
>>
> 
> This '/tools' error from   '/lib'  needs some solution.
> 
> Currently /lib reports  1 success, 0 error - and potential error state is
> returned via some other mechanism (i.e. setting struct member...)
> 
> On the other hand the lvm2app is seriously missing error reporting - since
> the user of this API is usually not seeing typical lvm2 log_error messages.

I have been getting the error message text back to the caller, but the
error codes are lacking.  These changes are yet to come.

-Tony


