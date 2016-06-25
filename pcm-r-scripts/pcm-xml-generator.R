
file <- tail(commandArgs(), n=1)

if (!file.exists(file)) {
    msg <- cat(paste('Specified file "', file, '" does not appear to exist.\n', sep=''))
    stop(msg)
}

geneCodes <- if (file.exists('gene-codes.rds')) {
    readRDS('gene-codes.rds')
} else {
    hash()
}

loadPkg <- function(x)
  {
    if (!require(x,character.only = TRUE))
    {
      install.packages(x,dep=TRUE,repos='http://cran.us.r-project.org')
        if(!require(x,character.only = TRUE)) stop('Package not found')
    }
  }

loadPkg('XML')
loadPkg('rjson')
loadPkg('hash')
loadPkg('RCurl')

getHGNCID <- function(symbol) {

    if (has.key(symbol, geneCodes) == FALSE) {
        cat(paste('Querying HGNC API for symbol "', symbol, '"...\n', sep=''))

        response <- getURLContent(paste('http://rest.genenames.org/fetch/symbol/', symbol, sep=''), httpheader = c(Accept = 'application/json'))

        json <- fromJSON(response)
        split <- strsplit(json[['response']][['docs']][[1]][['hgnc_id']], ':')

        geneCodes[[symbol]] <- paste('C', split[[1]][[2]], sep='')
    }

    return(geneCodes[[symbol]])
}

genRandomBirthdate <- function(N, st="1900/01/01", et="1975/01/01") {
    st <- as.POSIXct(as.Date(st))
    et <- as.POSIXct(as.Date(et))
    dt <- as.numeric(difftime(et,st,unit="sec"))
    ev <- sort(runif(N, 0, dt))
    rt <- st + ev
}

createRootNode <- function(patientMRN) {
    root <- newXMLNode('feed')
    xmlAttrs(root)['xmlns'] = 'http://www.w3.org/2005/Atom'
    newXMLNode('title', paste('Vanderbilt FHIR Resources for Patient', patientMRN), parent = root)

    return(root)
}

createPatientEntry <- function(mrn, first, middle, last, rootNode) {
    patientEntry <- newXMLNode('entry', parent = rootNode)
    newXMLNode('title', 'Vanderbilt Patient Resource')
    newXMLNode('id', paste('Patient/', mrn, sep=''), parent = patientEntry)
    content <- newXMLNode('content', parent = patientEntry)
    patientElement <- newXMLNode('Patient', parent = content)
    xmlAttrs(patientElement)['id'] = paste('Patient/', mrn, sep='')
    xmlAttrs(patientElement)['xmlns'] = 'http://hl7.org/fhir'
    textNode <- newXMLNode('text', parent = patientElement)
    newXMLCDataNode(paste('\n<div xmlns="http://www.w3.org/1999/xhtml">\n<p>\n', last, ', ', first, ' ', middle, '\n</p>\n</div>\n', sep=''), textNode)
    name <- newXMLNode('name', parent = patientElement)
    use <- newXMLNode('use', parent = name)
    xmlAttrs(use)['value'] = 'official'
    family <- newXMLNode('family', parent = name)
    xmlAttrs(family)['value'] = last
    given <- newXMLNode('given', parent = name)
    xmlAttrs(given)['value'] = paste(first, middle)
    gender <- newXMLNode('gender', parent = patientElement)
    coding <- newXMLNode('coding', parent = gender)
    system <- newXMLNode('system', parent = coding)
    xmlAttrs(system)['value'] = 'http://hl7.org/fhir/v3/AdministrativeGender'
    code <- newXMLNode('code', parent = coding)
    display <- newXMLNode('display', parent = coding)
#    if (mrn > 1 && mrn %% 2) {
        xmlAttrs(code)['value'] = 'F'
        xmlAttrs(display)['value'] = 'Female'
#    } else {
#        xmlAttrs(code)['value'] = 'M'
#        xmlAttrs(display)['value'] = 'Male'
#    }
    birth_date <- newXMLNode('birthDate', parent = patientElement)
    xmlAttrs(birth_date)['value'] = paste(format(genRandomBirthdate(1), '%Y-%m-%d'), 'T00:00:00-00:00', sep='')
}

createObservationEntry <- function(id, patientMRN, histology, pos, chr, var, geneName, geneID, rootNode) {
    obsEntry <- newXMLNode('entry', parent = rootNode)
    newXMLNode('title', 'Vanderbilt Observation Resource', parent = obsEntry)
    newXMLNode('id', paste('Observation/', id, sep=''), parent = obsEntry)
    content <- newXMLNode('content', parent = obsEntry)
    obsElement <- newXMLNode('Observation', parent = content)
    xmlAttrs(obsElement)['id'] = paste('Observation/', i, sep='')
    xmlAttrs(obsElement)['xmlns'] = 'http://hl7.org/fhir'
    ext <- newXMLNode('extension', parent = obsElement)
    xmlAttrs(ext)['url'] = 'http://hl7.org/fhir/StructureDefinition/geneticsReferenceAllele'
    ext <- newXMLNode('extension', parent = obsElement)
    xmlAttrs(ext)['url'] = 'http://hl7.org/fhir/StructureDefinition/geneticsObservedAllele'
    ext <- newXMLNode('extension', parent = obsElement)
    xmlAttrs(ext)['url'] = 'http://hl7.org/fhir/StructureDefinition/geneticsAlleleName'
    valueCoding <- newXMLNode('valueCoding', parent = ext)
    display <- newXMLNode('display', parent = valueCoding)
    xmlAttrs(display)['value'] = pos
    ext <- newXMLNode('extension', parent = obsElement)
    xmlAttrs(ext)['url'] = 'http://hl7.org/fhir/StructureDefinition/geneticsAssessedCondition'
    valueString <- newXMLNode('valueString', parent = ext)
    xmlAttrs(valueString)['value'] = histology
    ext <- newXMLNode('extension', parent = obsElement)
    xmlAttrs(ext)['url'] = 'http://hl7.org/fhir/StructureDefinition/geneticsDNASequenceVariation'
    valueString = newXMLNode('valueString', parent = ext)
    xmlAttrs(valueString)['value'] = var
    ext <- newXMLNode('extension', parent = obsElement)
    xmlAttrs(ext)['url'] = 'http://hl7.org/fhir/StructureDefinition/geneticsGeneId'
    valueCodeableConcept <- newXMLNode('valueCodeableConcept', parent = ext)
    coding <- newXMLNode('coding', parent = valueCodeableConcept)
    system <- newXMLNode('system', parent = coding)
    xmlAttrs(system)['value'] = 'http://www.genenames.org'
    code <- newXMLNode('code', parent = coding)
    xmlAttrs(code)['value'] = geneID
    display <- newXMLNode('display', parent = coding)
    xmlAttrs(display)['value'] = geneName
    valueCodeableConcept <- newXMLNode('valueCodeableConcept', parent = obsElement)
    subject <- newXMLNode('subject', parent = obsElement)
    reference <- newXMLNode('reference', parent = subject)
    xmlAttrs(reference)['value'] = paste('Patient/', patientMRN, sep='')
}

drID <- 1
createDiagnosticReportEntry <- function(patientMRN, obsIDList, rootNode) {
    drEntry <- newXMLNode('entry', parent = rootNode)
    newXMLNode('title', 'Vanderbilt DiagnosticReport Resource', parent = drEntry)
    newXMLNode('id', paste('DiagnosticReport/', drID, sep=''), parent = drEntry)
    drID <- drID + 1
    content <- newXMLNode('content', parent = drEntry)
    drElement <- newXMLNode('DiagnosticReport', parent = content)
    xmlAttrs(drElement)['id'] = paste('DiagnosticReport/', drID, sep='')
    xmlAttrs(drElement)['xmlns'] = 'http://hl7.org/fhir'
    subject <- newXMLNode('subject', parent = drElement)
    reference <- newXMLNode('reference', parent = subject)
    xmlAttrs(reference)['value'] = paste('Patient/', patientMRN, sep='')

    for (obsID in obsIDList) {
        result <- newXMLNode('result', parent = drElement)
        reference <- newXMLNode('reference', parent = result)
        xmlAttrs(reference)['value'] = paste('Observation/', obsID, sep='')
    }
}

exportXML <- function(patientMRN, rootNode) {
    doc <- xmlDoc(rootNode)
    write(saveXML(doc), paste('patient-xml/patient-', patientMRN, '.xml', sep = ''))
}


load(file, inputData<-new.env())

currentMRN <- NULL
rootNode <- NULL
obsIDList <- list()
x <- 1

for (i in 1:dim(inputData$foo['mrn'])[1]) {

    geneName <- inputData$foo[i, 'gene.name']

    if (geneName == 'MYCL1') {
        next
    }

    mrn <- as.character(inputData$foo[i, 'mrn'])

    if (is.null(currentMRN) || currentMRN != mrn) {

        if (!is.null(rootNode)) {
            createDiagnosticReportEntry(currentMRN, obsIDList, rootNode)
            exportXML(currentMRN, rootNode)

            rootNode <- NULL
        }

        currentMRN <- mrn
        rootNode <- createRootNode(currentMRN)

        cat(paste('Creating XML file for Patient: ', mrn, ' - ', inputData$foo[i, 'last'], ', ', inputData$foo[i, 'first'], ' ', inputData$foo[i, 'middle'], '\n', sep=''))

        createPatientEntry(currentMRN, inputData$foo[i, 'first'], inputData$foo[i, 'middle'], inputData$foo[i, 'last'], rootNode)

        x <- 1
        obsIDList <- list()
    }

    obsIDList[[x]] <- i
    x <- x + 1

    geneID <- getHGNCID(geneName)

    createObservationEntry(i, currentMRN, inputData$foo[i, 'histology'], inputData$foo[i, 'pos'], inputData$foo[i, 'chr'], inputData$foo[i, 'var'], inputData$foo[i, 'gene.name'], geneID, rootNode)
}

if (!is.null(rootNode)) {
    createDiagnosticReportEntry(currentMRN, obsIDList, rootNode)
    exportXML(currentMRN, rootNode)
}

saveRDS(geneCodes, file='gene-codes.rds')

cat('\nExecution completed.\n\n')
