import {describe, test} from "@jest/globals";
import {Client} from "pg";
import {parseDatabaseUrl} from "@azimutt/database-types";
import {connect} from "../src/connect";
import {application} from "./constants";
import {execQuery} from "../src/common";
import { RedshiftClient, DescribeClustersCommand } from "@aws-sdk/client-redshift";
import { RedshiftDataClient, ExecuteStatementCommand } from "@aws-sdk/client-redshift-data";
import { fromIni } from "@aws-sdk/credential-providers";

// use this test to troubleshoot connection errors
// if you don't succeed with the first one (Azimutt code), try with the second one (node lib) and tell us how to fix ;)
describe('connect', () => {
    const url = 'postgresql://postgres:postgres@localhost:5432/azimutt_dev'
    const parsedUrl = parseDatabaseUrl(url)
    const query = 'SELECT * FROM users LIMIT 2;'

    test.skip('should connect to postgres', async () => {
        const results = await connect(application, parsedUrl, execQuery(query, []))
        console.log('results', results)
    })

    test.skip('should connect to postgres', async () => {
        const client = new Client({
            application_name: application,
            connectionString: url
        })
        await client.connect()
        const results = await client.query(query)
        console.log('results', results)
        await client.end()
    })

    test('should connect to redshift', async () => {
        const credentials = fromIni({ profile: '928503743707_DevProdRedshiftRole' })
        const tmp = await credentials()
        console.log(tmp.sessionToken)

        const redClient = new RedshiftClient({ region: "eu-central-1", credentials })
        const redCommand = new DescribeClustersCommand({});
        console.log(await redClient.send(redCommand))

        const client = new RedshiftDataClient({ region: "eu-central-1", credentials });
        console.log(client)
        const input = { // BatchExecuteStatementInput
          Sql: "SELECT 1 FROM db_prod.accounts;",
          ClusterIdentifier: "datafoundation-reporting",
          DbUser: "alexandre.chakroun@doctolib.com",
          Database: "doctored", // required
        };
        const command = new ExecuteStatementCommand(input);
        const response = await client.send(command);
        console.log('response', response);
    })
})
