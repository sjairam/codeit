import http from 'k6/http';
import { sleep } from 'k6';

export let options = {
    vus: 1,           // Number of virtual users
    duration: '60s',  // Duration of the test
};

// ARCHIVED 
// https://bibdata-dev.lib.harvard.edu
// https://booklabeler-dev.lib.harvard.edu

const urls = [ 
    'https://acorn-dev.lib.harvard.edu/records/list',   //ACORN
    'https://arclight-dev.lib.harvard.edu/',
    'https://api-dev.lib.harvard.edu/v2/items',         //LibraryCloud
    'https://aspace-dev.lib.harvard.edu',               // Aspace 1
    'https://aspaceapi-dev.lib.harvard.edu',            // Aspace 2
    'https://aspacepui-dev.lib.harvard.edu',            // Aspace 3
    'https://collex-dev.lib.harvard.edu',
    'https://curiosity-dev.lib.harvard.edu',
    'https://dims-dev.lib.harvard.edu/readiness',
    'https://drs2-services-dev.hul.harvard.edu/',
    'https://drs2-dev.hul.harvard.edu',
    'https://drs2-dev.hul.harvard.edu/drs2_webadmin/search',
    'https://drsmdsrv-dev.lib.harvard.edu/drs_metadata/rest/heartbeat',         //MDS
    'https://drs-id-mongo-publisher-dev.lib.harvard.edu/api/healthcheck',       //OCFL-Validator
    'https://eadchecker-dev.lib.harvard.edu',
    'https://eda-dev.lib.harvard.edu',
    'https://embed-dev.lib.harvard.edu',                            //Viewer
    'https://fts-dev.lib.harvard.edu',
    'https://hgl-dev.lib.harvard.edu',
    'https://ids-dev.lib.harvard.edu/ids/view/400013131',
    'https://iiif-dev.lib.harvard.edu',         //IDS
    'https://jstor-dev.lib.harvard.edu', 
    'https://jobmon-dev.lib.harvard.edu',
    'https://lc-tools-dev.lib.harvard.edu/oai/?verb=ListSets',      //LibraryCloud
    'https://lc-tools-dev.lib.harvard.edu/csv/',                    //LibraryCloud
    'https://listview-dev.lib.harvard.edu',
    'https://lts-pipelines-dev.lib.harvard.edu/login',
    'https://mps-dev.lib.harvard.edu/assets/images/drs:400008794/full/full/0/default.jpg',
    'https://mps-dev.lib.harvard.edu/assets/image/DRS:400013059/full/full/0/default.jpg',
    'https://nrsadmin-dev.lib.harvard.edu/resources/search/advanced',
    'https://nrsadmin-api-dev.lib.harvard.edu',
    'https://nrs-dev.lib.harvard.edu/URN-3:HUL.OIS:1254828:MANIFEST:2',
    'https://nrs-dev.lib.harvard.edu/URN-3:HUL.OIS:1254828:MANIFEST:3',
    'https://olivia-dev.lib.harvard.edu/olivia/servlet/OliviaServlet?storedProcedure=getUrn&callingApplication=call1&oracleID=400299701',
    'https://pds-dev.lib.harvard.edu',          //IDS
    'https://policyadmin-dev.lib.harvard.edu/policy/servlet/admin',
    'https://tools-dev.lib.harvard.edu',
    'https://viewer-dev.lib.harvard.edu',                           //Viewer  
    'https://webservices-dev.lib.harvard.edu/rest/v3/hollis/barcode/32044051654705',    //Presto
    'https://whistle-dev.lib.harvard.edu',
    'https://cluster-console.dev.lib.harvard.edu',
    'https://deployment.dev.lib.harvard.edu',
    // 'https://another-site.com',
];

export default function () {
    for (let url of urls) {
        let response = http.get(url);
        console.log(`Response time for ${url}: ${response.timings.duration} ms`);
        sleep(1);  // Wait for 1 second between requests
    }
}
