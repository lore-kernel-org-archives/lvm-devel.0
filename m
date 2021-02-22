From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Mon, 22 Feb 2021 13:38:08 +0100
Subject: [PATCH]unit-test: modify the test case to support systems with PAGE_SIZE of 64K
In-Reply-To: <be093e24-7d0b-a929-d092-4854878196ec@huawei.com>
References: <be093e24-7d0b-a929-d092-4854878196ec@huawei.com>
Message-ID: <15f1fd31-e10f-47f8-9dda-13fb8cfb99fb@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 22. 02. 21 v 9:01 Wu Guanghao napsal(a):
> Hi
> 
> Now we want to compile lvm2 on a machine whose PAGE_SIZE is 64K and
> enable unit test at the same time. However, we found that some test cases
> cannot be executed normally, so we made some modifications.
> 
> 
>> -#define T_BLOCK_SIZE 4096
> +#define T_BLOCK_SIZE 65536
>   #define NR_BLOCKS 64
>   #define INIT_PATTERN 123

Hi

Whole patch likely needs to be based on some 'configure' discovered define
(likely  sysconf(_SC_PAGESIZE))

So the patch itself cannot turn everything into 64K - but should adapt 
dynamically to system condition (so the existing coverage is not lost/changed).

Regards


Zdenek


