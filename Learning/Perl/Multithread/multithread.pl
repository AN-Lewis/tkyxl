#!/usr/bin/perl
use strict;
use threads;
 
sub prime
{
        my $number = shift;
        my $d = 2;
        my $sqrt = sqrt $number;
        while( 1 )
        {
                if( $number%$d == 0 )
                {
                        return 0;
                }
                if ($d < $sqrt)
                {
                        $d++;
                } else {
                        return 1;
                }
        }
}
 
sub boss
{
        # Generate blocks of numbers and have workers check for primes.
        my $i = 0;
        my @workers = ();
        while ( $i < 9223372036854775000 )
        {
                my @threads = threads->list(threads::running);
                if( $#threads < 250 ) # 250 maximum threads
                {
                        push( @workers, threads->create( \&worker, $i, $i+1000 ) ); # Have worker process a block of 1000 numbers.
                        foreach ( @workers )
                        {
                                if( $_->is_joinable() ) {
                                        $_->join();
                                }
                        }
                        $i=$i+1001; # incriment count.
                }
        }
       
        # Wait until all threads finish.
        my @threads = threads->list(threads::running);
        while($#threads > 0)
        {
                my @threads = threads->list(threads::running);
        }
}
 
sub worker
{
        my ($i, $end) = @_;
        while( $i <= $end )
        {
                if( prime( $i ) == 1 )
                {
                        print $i."\n";
                }
                $i++;
        }
        threads->exit();
}
 
boss(); # Start boss process.