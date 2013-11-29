From: dongmao zhang <dmzhang@suse.com>
Date: Fri, 29 Nov 2013 14:06:39 +0800
Subject: [PATCH] clvmd: closedown the cluster after finishing of lvm_thread
In-Reply-To: <52974BE7.1080206@redhat.com>
References: <1385542604-11708-1-git-send-email-dmzhang@suse.com>
	<52974BE7.1080206@redhat.com>
Message-ID: <52982EEF.3020104@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

? 2013?11?28? 21:57, Zdenek Kabelac ??:
> Dne 27.11.2013 09:56, dongmao zhang napsal(a):
>> when lvm_thread is processing remote request, the clvmd
>> received a SIG_TERM, it will free cluster resource before
>> the realwork of lvm_thread is done. If freeing the cluster
>> resource happens before send_message, it would cause the
>> remote command hangs forever.
>>
>> this patch move closedown after the closing the working thread.
>> ---
>> daemons/clvmd/clvmd.c | 3 ++-
>> 1 files changed, 2 insertions(+), 1 deletions(-)
>>
>> diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
>> index d57c0fd..b2f7dd5 100644
>> --- a/daemons/clvmd/clvmd.c
>> +++ b/daemons/clvmd/clvmd.c
>> @@ -621,6 +621,8 @@ int main(int argc, char *argv[])
>> if ((errno = pthread_join(lvm_thread, NULL)))
>> log_sys_error("pthread_join", "");
>>
>> + clops->cluster_closedown();
>> +
>> close_local_sock(local_sock);
>> destroy_lvm();
>>
>> @@ -979,7 +981,6 @@ static void main_loop(int local_sock, int 
>> cmd_timeout)
>> }
>>
>> closedown:
>> - clops->cluster_closedown();
>> if (quit)
>> DEBUGLOG("SIGTERM received\n");
>> }
>
>
> It's not clear to me how this code move helps to anything.
>
> You just moved call of clops->cluster_closedown(); after joining thread?
>
> In which code path this patch is changing something ?
>
> Zdenek
>
>

hi Zdenek,
thank you for you reply. The main idea is that the lvm_thread_fn is 
using cluster resources(such as using cpg_handler in send_message), we 
could not free cluster resource until lvm_thread_fn finishs.

The 'lvm_thread_fn' thread is doing 'process_work_item' in which it will 
send reply message(cluster_send_message) back
to remote nodes. The cluster_send_message is using the cluster resource. 
So it means we can not free the cluster resource before lvm_thread_fn 
really is finished. The cluster_closedown in the main thread could 
possibly happen before lvm_thread_fn thread calls send_message.

If so, it could cause a sending message failure, moreover, the remote 
node can not get the response, it has to wait a timeout to finish.

I met a bug like this: two nodes with VG resource.
1. NodeA runs 'rcopenais stop'
2. NodeB runs 'vgscan'

in some time, vgscan could hang for a while waiting all cluster nodes' 
response.
Because unfortunately clvmd on NodeA can not send back message because 
cluster_closedown happens before send_message.


Dongmao Zhang





















