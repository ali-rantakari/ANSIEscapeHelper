#!/usr/bin/perl

use Term::ANSIColor qw(:constants);

# CLEAR, RESET, BOLD, DARK, UNDERLINE, UNDERSCORE, BLINK, REVERSE, CONCEALED, BLACK, RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE, ON_BLACK, ON_RED, ON_GREEN, ON_YELLOW, ON_BLUE, ON_MAGENTA, ON_CYAN, and ON_WHITE

print "some", BLUE, " blue", RESET, " and some ", RED, "red\n";
print YELLOW, "yellow", RESET, " and ", CYAN, "cyan and ", MAGENTA, "magenta", RESET, "\n";

print "\n";

print ON_YELLOW, BLUE, "blue on yellow go sweden :)", ON_BLUE, WHITE, " okay lets get serious now\n", CLEAR;

print "\n";

print RED, "red.";