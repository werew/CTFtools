/*
    Generates a trace with the address of each routine or basic block executed.

    Substantial part of this code was borrowed from:
    http://doar-e.github.io/blog/2013/08/31/some-thoughts-about-code-coverage-measurement-with-pin/#our-pintool

    Therefore, thank you 0vercl0k :)

    Some tips:
    - Use option -b to trace baic blocks
    - Add/remove dynamic libs path to untrace/trace them (you can comment out
      the check at Instrument_image to blacklist all dynamically loaded libs)
    - It can be useful to disable ASLR 

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.         
*/
#include <pin.H>
#include <map>
#include <string>
#include <iostream>
#include <stdio.h>


/*********************  Types  ****************************/
typedef std::map<std::string, std::pair<ADDRINT, ADDRINT>> MODULE_BLACKLIST_T;


/************* Some global stuffs *************************/

// This is the list of the blacklisted module ; you can find their names & start/end addresses
MODULE_BLACKLIST_T blacklisted_modules;
// Log file
FILE* outfile;


/************** Command line arguments ********************/

// You can set a timeout (in cases the application never ends)
KNOB<std::string> KnobTimeoutMs(KNOB_MODE_WRITEONCE,"pintool",
    "r", "infinite", "Set a timeout for the instrumentation");

KNOB<string> KnobOutputFile(KNOB_MODE_WRITEONCE, "pintool",
    "o", "pp.out", "specify output file name");

KNOB<BOOL> KnobTraceBBL(KNOB_MODE_WRITEONCE, "pintool",
    "b", "0", "trace basic blocks instead of functions");

/************** Utility functions    ***********************/

// Walk the modules_blacklisted list and check if 
// address belongs to one of the blacklisted module
bool ins_is_blacklisted(ADDRINT address){

    MODULE_BLACKLIST_T::const_iterator it;

    for(it  = blacklisted_modules.begin(); 
        it != blacklisted_modules.end(); ++it){

        ADDRINT low_address  = it->second.first;
        ADDRINT high_address = it->second.second;

        if(address >= low_address && 
           address <= high_address) return true;
    }

    return false;
}

// Check is image_path matches one of the string in the blacklist
bool module_is_blacklisted(const std::string &image_path)
{
    // If the path of image matches one of the following string, the module
    // won't be instrumented by Pin. This way you can avoid instrumentation of
    // external libraries
    static char const* path_to_blacklist[] = {
        "C:\\Windows\\",
        // "C:\\Windows\\system32\\",
        // "C:\\Windows\\WinSxS\\",
        "[vdso]",
        "/lib64/ld-linux-x86-64.so.2",
        "/lib/x86_64-linux-gnu/libselinux.so.1",
        "/lib/x86_64-linux-gnu/libc.so.6",
        "/lib/x86_64-linux-gnu/libpcre.so.3",
        "/lib/x86_64-linux-gnu/libdl.so.2",
        "/lib/x86_64-linux-gnu/libpthread.so.0"
    };

    unsigned int i;
    unsigned int len = sizeof(path_to_blacklist) / sizeof(path_to_blacklist[0]);
    for(i = 0; i < len; ++i){
        if (strncmp(path_to_blacklist[i], image_path.c_str(), 
                    strlen(path_to_blacklist[i])) == 0) return true;
    }

    return false;
}







/************* Instrumentation/Analysis functions **************/

INT32 Usage(){
    std::cerr << "This pintool allows you to generate "
                 "a file that will contain the "
                 "address of each basic block executed." 
              << std::endl << std::endl;
    std::cerr << std::endl << KNOB_BASE::StringKnobSummary() 
              << std::endl;
    return -1;
}


// Called right before the execution of each basic block 
VOID PIN_FAST_ANALYSIS_CALL handle_basic_block(ADDRINT address_bbl){
    fprintf(outfile,"%#lx\n",address_bbl);
}

// Called right before the execution of each function 
VOID PIN_FAST_ANALYSIS_CALL handle_routine(ADDRINT address_rtn){
    fprintf(outfile,"%#lx\n",address_rtn);
}


// We have to instrument traces in order to instrument each BBL, 
// the API doesn't have a BBL_AddInstrumentFunction
VOID Instrument_trace(TRACE trace, VOID *v){

    // We don't want to instrument the BBL contained in external libs
    if(ins_is_blacklisted(TRACE_Address(trace))) return;


    for(BBL bbl = TRACE_BblHead(trace); BBL_Valid(bbl); bbl = BBL_Next(bbl)){

        /* Insert a call to handle_basic_block before every basic block,
           passing the number of instructions Use a faster linkage for calls to
           analysis functions: add PIN_FAST_ANALYSIS_CALL to the declaration between
           the return type and the function name. You must also add
           IARG_FAST_ANALYSIS_CALL to the InsertCall.  */
        BBL_InsertCall(
            bbl,
            IPOINT_ANYWHERE,
            (AFUNPTR)handle_basic_block,
            IARG_FAST_ANALYSIS_CALL, 
            IARG_ADDRINT, BBL_Address(bbl),
            IARG_END
        );
    }
}


VOID Instrument_routine(RTN rtn, VOID * v){

    // We don't want to instrument the functions contained in external libs
    if(ins_is_blacklisted(RTN_Address(rtn))) return;

    RTN_Open(rtn);

    RTN_InsertCall(
        rtn,
        IPOINT_BEFORE,
        (AFUNPTR)handle_routine,
        IARG_FAST_ANALYSIS_CALL, 
        IARG_ADDRINT, RTN_Address(rtn),
        IARG_END
    );

    RTN_Close(rtn);
}

// Instrumentation of the modules
VOID Instrument_image(IMG img, VOID * v){

    // Never blacklist main executable
    if(IMG_IsMainExecutable(img)) return;


    // Image is not blacklisted
    const string image_path = IMG_Name(img);
    if (module_is_blacklisted(image_path) == false) return; // Comment this out to blacklist every image


    // Blacklist address range
    ADDRINT module_low_limit  = IMG_LowAddress(img);
    ADDRINT module_high_limit = IMG_HighAddress(img); 


    pair<string, pair<ADDRINT, ADDRINT>> module_info = make_pair(
        image_path, make_pair(module_low_limit, module_high_limit)
    );


    blacklisted_modules.insert(module_info);
}



VOID Fini(INT32 code, VOID *v){
    fclose(outfile);
}



int main(int argc, char *argv[]){

    // Initialize PIN library. Print help message if -h(elp) is specified
    // in the command line or the command line is invalid 
    if(PIN_Init(argc,argv)) return Usage();

    // Open log file
    outfile = fopen(KnobOutputFile.Value().c_str(), "w");
    if (outfile == NULL) {
        perror("fopen");
        return -1;
    }

   
    if (KnobTraceBBL){ 
        // Register function to be called to instrument traces
        TRACE_AddInstrumentFunction(Instrument_trace, 0);
    } else {
        // Register function to be called to instrument functions
        RTN_AddInstrumentFunction(Instrument_routine, 0);
    }


    // Register function to be called when the application exits
    PIN_AddFiniFunction(Fini, 0);
    
    // Register function to be called when a module is loaded
    IMG_AddInstrumentFunction(Instrument_image, 0);

    PIN_StartProgram();
    
    return 0;
}
