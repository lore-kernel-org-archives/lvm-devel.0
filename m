From: Lidong Zhong <lidong.zhong@suse.com>
Date: Wed, 5 Oct 2022 13:34:13 +0800
Subject: [RFC PATCH] lvmlockd: purge the lock resources left in previous lockspace
In-Reply-To: <20220930153251.GA1502@redhat.com>
References: <ff6e311a-5e87-2fe8-7c11-46aa7aaa048e@suse.com>
 <20220930153251.GA1502@redhat.com>
Message-ID: <ae1ec033-2f0c-ac5f-a462-7e33bb364f2a@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 9/30/22 23:32, David Teigland wrote:
> On Fri, Sep 30, 2022 at 09:57:08PM +0800, Lidong Zhong wrote:
>>  ???? /* FIXME: purge any remaining orphan locks in each rejoined ls? */
> You're fixing it, so we can drop the comment.
>
>> +??? ??? ??? ??? file = fopen(ls_comms_path, "r");
>> +??? ??? ??? ??? if (!file)
>> +??? ??? ??? ??? ??? continue;
>> +??? ??? ??? ??? if (fgets(line, LOCK_LINE_MAX, file)) {
>> +??? ??? ??? ??? ??? rv = sscanf(line, "%d", &val);
>> +??? ??? ??? ??? ??? if (rv == 1)
>> +??? ??? ??? ??? ??? ??? return val;
> Is this missing an fclose?
>
> Please confirm that this works for your test case and I'll include it.

Hi David,

I have made the modifications based on your review. Thanks.

The patch works in my test. I am sending the new version patch as an 
attachment. Sorry if it causes any

inconvenience.


Regards,

Lidong


>
> Thanks,
> Dave
>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 0001-lvmlockd-purge-the-lock-resources-left-in-previous-l.patch
Type: text/x-patch
Size: 4927 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20221005/15fa3d1b/attachment.bin>
