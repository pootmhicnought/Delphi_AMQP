# Delphi_AMQP
AMQP protocol based on now massively fragmented https://github.com/delphiripper/comotobo

I was looking for full source AMQP for Delphi and after a ton of digging found one that seemed to be close to functional.  Then I found there were 13 forks and multiple old PR's.

I tried a few forks, some better than others but none actually functional (many wouldn't even compile).

So far this appears 100% functional under Delphi 10.4 with RabbitMQ 3.9.9 on top of Erlang/OTP 24.1.5

I've only been testing the features I need at this point.

Did a quick test under FMX, and working there as well.  I'll be using it a project targettig android,win32 and win64 over the next weeks.
