*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download orders file
    ${orders}=    Get orders
    FOR    ${order}    IN    @{orders}
        Close the annoying modal
        Select From List By Value    head    ${order}[Head]
        Click Button    id-body-${order}[Body]
        Input Text    //input[@placeholder="Enter the part number for the legs"]    ${order}[Legs]
        Input Text    //input[@placeholder="Shipping address"]    ${order}[Address]
        WHILE    True
            Click Button    order
            ${error}=    Is Element Visible    //div[@class="alert alert-danger"]
            IF    $error == $False    BREAK
        END
        ${receiptNum}=    Get receipt
        ${pdf}=    Store the receipt as a PDF file    ${receiptNum}
        Click Button    order-another
    END
    [Teardown]    Close the browser


*** Keywords ***
Store the receipt as a PDF file
    [Arguments]    ${order number}
    ${order_results_html}=    Get Element Attribute    receipt    outerHTML
    Html To Pdf    ${order_results_html}    output/tempPDF/${order number}.pdf

Get receipt
    ${return}=    Get Text    //p[@class="badge badge-success"]
    RETURN    ${return}

Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download orders file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Close the browser
    Close Browser

Get orders
    ${orders}=    Read table from CSV    orders.csv
    RETURN    ${orders}

Close the annoying modal
    Click Button    Yep

Fill the form
    [Arguments]    ${order}
    RETURN ${order}
